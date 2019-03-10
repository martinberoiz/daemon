import time
DELAY = 10

def main():
    while(True):
        time.sleep(DELAY)
        print("Hello from a script! It's been {} seconds since last time.".format(DELAY))

if __name__ == "__main__":
    main()
