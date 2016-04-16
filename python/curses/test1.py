#!/usr/bin/env python

import curses


def main(stdscr):
    msg = 'Hello World'

    stdscr.addstr(msg)
    stdscr.move(0, 0)

    x = 0

    while True:
        c = stdscr.getch()
        if c == ord('h'):
            x = max(x - 1, 0)
        elif c == ord('l'):
            x = min(x + 1, len(msg) - 1)
        elif c == ord('j'):
            msg = msg[:x] + chr(ord(msg[x]) - 1) + msg[x + 1:]
        elif c == ord('k'):
            msg = msg[:x] + chr(ord(msg[x]) + 1) + msg[x + 1:]

        stdscr.addstr(0, 0, msg)
        stdscr.move(0, x)
        stdscr.refresh()


if __name__ == '__main__':
    curses.wrapper(main)
