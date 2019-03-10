# How to write systemd daemons using Python

A daemon is a basically a background process; a program that runs continuously, most of the time waiting for external input to do specific work.

In this article I explain how to write and deploy a Linux systemd service using Python.

Linux adopted [systemd](https://en.wikipedia.org/wiki/Systemd) as its "System and Service Manager", replacing the previous init system.

Systemd is tasked with starting and managing several "services", ie., background processes that provide system functionality on demand.

It is customary to add the letter d (for daemon) to programs that will run as services.

## Run a Python script as a background process

So, starting from the basic, Python scripts are files that are meant to run from the command line.

For example 

    import time
    DELAY = 10
    while(True):
        time.sleep(DELAY)
        print("Hello from a script! It's been {} seconds since last time.".format(DELAY))


If we run it,

    $ python myscript.py

It will run forever and print a statement every 10 s.
To stop it, simply enter ctrl+c (^C) on the console and it will kill the running process.

To make the process run in the background, we can append `&` to the command

    $ python myscript.py &

The use of the end ampersand will push myscript to the background and return the prompt for the next command. This way we have created a background process.

There are two problems with this approach.

The first one is that the process is terminated as soon as the user logs off.

The second is that there is no redirection of stdout and stderr (we could improve the example with pipes redirecting stdout, stderr, but it's not the point of this article).

To remedy these, we can use the command [nohup](https://en.wikipedia.org/wiki/Nohup), which is a POSIX command that ignores terminal's termination signal once we log out, so that the process can keep running.

    $ nohup python myscript.py &

This last command would be enough to create a daemon, and we could finish our tutorial at this point.

_Note: To terminate background processes initiated by nohup or appending ampersand, you can find the process PID with `ps -e` and terminate with `kill`_

    $ ps -e | grep python
    ...
    17490 ttys000    0:00.03 python myscript.py
    ...
    $ kill 17490


### Systemd Services

We can also make use of systemd to launch the process at start-up and restart it whenever it crashes to make sure we can always have it running. Systemd also provides a unique interface to start, stop and restart services. This last one (restart) is useful if we changed any configuration file and we want to restart the service with the new one.

The process to create a systemd service is fairly simple. All we need to do, is create a .service file in /etc/systemd/system/ directory with the name of the service.

For our example we'll use the file name mydaemond.service. Like we said before, it is customary to append a letter d after the service name.

Below is a minimal example of a service file.
We will copy the following to the file `/etc/systemd/system/mydaemond.service`
(Like we said before, it is customary to append a letter d after the service name.)

    [Unit]
    Description=My Awesome Service
    After=network.target
    
    [Service]
    Type=simple
    ExecStart=/home/myuser/myscript.py
    Restart=on-failure


Once the file is created we can start our service invoking `systemctl`:

    $ systemctl start mydaemond

And stop it:

    $ systemctl stop mydaemond

--------------

# Simplifying the installation

## Installing the python module with pip

It may be convenient to provide our users with an easy way to install both our python script and to register our service.

The standard way to install packages in Python is using pip, and for that we need a setup.py file.

A minimal setup.py to install a Python module looks like this:

    from setuptools import setup
    setup(name='mymodule',
          version='0.1',
          description='My Awesome Python Module',
          py_modules=['myscript', ],
         )

The difference between a Python module and a Python script is that the former is intended to be imported inside other modules or scripts, while the latter is intended to be run completely from the command line.

Modules don't usually have executable instructions in the global scope, only function definitions (and occasional variable declarations).

Scripts, on the other hand, have mostly executable instructions in the global scope.

We have written a script myscript.py so far (not a module), so this setup.py file would not help us.

We can reach a compromise between a module and a script, however, by encapsulating functionality in function definitions and only call them on the condition that it's run from the command line. 

Let's modify our myscript.py like this:

    import time
    DELAY = 10
    def main():
        while(True):
            time.sleep(DELAY)
            print("Hello from a script! It's been {} seconds since last time.".format(DELAY))

If we run the script as it is, nothing will be done because the main loop is inside a function that is never called. On the upside, importing it will not do any harm, since the loop is not going to be executed.

Most importantly, our script can already be installed with pip:

    $ pip install .
    $ python
    >>> import myscript
    >>> myscript.main()
    Hello from a script! It's been 10 seconds since last time.
    Hello from a script! It's been 10 seconds since last time.
    ...

It will still do nothing if executed from the command line:

    $ python myscript.py
    $
