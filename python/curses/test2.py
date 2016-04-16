#!/usr/bin/env python

import curses


def main(stdscr):
    x, y = 0, 0
    scrolly = 0
    navigate = False

    maxy, maxx = stdscr.getmaxyx()
    pad = curses.newpad(maxy, maxx)

    while True:
        c = stdscr.getch()

        if c == ord(' '):
            navigate = not navigate
            continue

        if navigate:
            if c == ord('h'):
                x = max(x - 1, 0)
            elif c == ord('l'):
                x += 1
            elif c == ord('j'):
                y += 1
            elif c == ord('J'):
                scrolly += 1
            elif c == ord('k'):
                y = max(y - 1, 0)
            elif c == ord('K'):
                scrolly = max(scrolly - 1, 0)
            elif c == ord('0'):
                x = 0
            elif c == ord('q'):
                break

            pad.move(y, x)
        else:
            pad.addch(y, x, chr(c))
            x += 1

        pad.refresh(scrolly, 0, 0, 0, maxy, maxx)


if __name__ == '__main__':
    curses.wrapper(main)
