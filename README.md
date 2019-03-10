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

_Note: To terminate background processes initiated by nohup or appending ampersand, you can find the process with ps -e and terminate with kill_

    $ ps -e | grep python
    ...
    17490 ttys000    0:00.03 python myscript.py
    ...
    $ kill 17490
