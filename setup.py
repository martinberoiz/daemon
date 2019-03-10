from setuptools import setup

setup(name='mymodule',
      version='0.1',
      description='My Awesome Python Module',
      py_modules=['myscript', ],
      entry_points={
        'console_scripts': [
            'mydaemon = myscript:main',
        ],
      },
     )
