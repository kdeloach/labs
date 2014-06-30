from __future__ import division
from collections import defaultdict
import random

GUARD, PRIEST, BARON, HANDMAID, PRINCE, KING, COUNTESS, PRINCESS = range(8)

LOSE = 0
NO_ACTION = 1

def log(message, *args):
    return
    print message.format(*args)

def deck():
    """Return deck of cards."""
    return [
        PRINCESS,
        COUNTESS,
        KING,
        PRINCE,
        PRINCE,
        HANDMAID,
        HANDMAID,
        BARON,
        BARON,
        PRIEST,
        PRIEST,
        GUARD,
        GUARD,
        GUARD,
        GUARD,
        GUARD
    ]

def card_action(p1, card_value):
    p1.protected = False
    if card_value == PRINCESS:
        return LOSE
    elif card_value == COUNTESS:
        return NO_ACTION
    elif card_value == KING:
        p2 = p1.strategy.trade_who()
        if p2:
            # Swap cards.
            p1.cards[0], p2.cards[0] = p2.cards[0], p1.cards[0]
            log('{0} swapped cards with {1}', p1.name, p2.name)
        else:
            log('Nobody to trade with')
    elif card_value == PRINCE:
        p2 = p1.strategy.discard_who()
        # Must discard own card if no other valid players.
        if not p2:
            p2 = p1
        if p1 == p2:
            log('{0} discarded their own hand', p1.name)
        else:
            log('{0} must discard and draw a new card', p2.name)
        c = p2.discard()
        if c != PRINCESS:
            p2.draw()
        else:
            log('{0} discarded the Princess and lost!', p2.name)
    elif card_value == HANDMAID:
        p1.protected = True
        log('{0} is now protected until their next turn', p1.name)
    elif card_value == BARON:
        p2 = p1.strategy.compare_who()
        if p2:
            log('{0} challenges {1}', p1.name, p2.name)
            c1, c2 = p1.cards[0], p2.cards[0]
            # Compare cards, player with lowest value loses.
            if c1 > c2:
                log('{0} lost!', p2.name)
                p2.discard()
            elif c1 < c2:
                log('{0} lost!', p1.name)
                p1.discard()
        else:
            log('Nobody to attack')
    elif card_value == PRIEST:
        p2 = p1.strategy.peek_who()
        if p2:
            p1.peek(p2)
            log('{0} peeked at {1}\'s hand', p1.name, p2.name)
        else:
            log('Nobody to spy on')
    elif card_value == GUARD:
        p2 = p1.strategy.guess_who()
        if p2:
            c = p1.strategy.guess_what(p2)
            log('{0} guesses {1} has the {2}...', p1.name, p2.name, card_name(c))
            if p2.cards[0] == c:
                log('Correct guess! {0} lost!', p2.name)
                p2.discard()
            else:
                log('Wrong guess')
        else:
            log('Nobody to attack')

def card_name(card_value):
    if card_value == PRINCESS:
        return 'Princess'
    if card_value == COUNTESS:
        return 'Countess'
    elif card_value == KING:
        return 'King'
    elif card_value == PRINCE:
        return 'Prince'
    elif card_value == HANDMAID:
        return 'Handmaid'
    elif card_value == BARON:
        return 'Baron'
    elif card_value == PRIEST:
        return 'Priest'
    elif card_value == GUARD:
        return 'Guard'

def which_card(cards):
    """Forced conditions."""
    # Lose if discarded.
    if PRINCESS in cards:
        return [c for c in cards if c != PRINCESS][0]
    # Discard if caught with King or Prince.
    if COUNTESS in cards:
        if KING in cards:
            return [c for c in cards if c != KING][0]
        if PRINCE in cards:
            return [c for c in cards if c != PRINCE][0]
    return -1

def other_players(p1):
    return [p for p in p1.world.players
        if p != p1
        and not p.protected
        and len(p.cards) > 0
    ]

def cards_played(world):
    """Return all discarded cards."""
    result = []
    return [
        card
        for p in world.players
        for card in p.graveyard
    ]

def hand_confidence(p1):
    """Return confidence of each card in player hand based on discarded cards."""
    pool = defaultdict(int)
    for card in deck():
        pool[card] += 1
    for card in cards_played(p1.world):
        pool[card] -= 1
    if COUNTESS in p1.graveyard:
        pool[PRINCE] *= 2
        pool[KING] *= 1.75
        pool[PRINCESS] *= 1.25
    total = sum(v for k, v in pool.iteritems())
    # Normalize
    result = [(k, v / total) for k, v in pool.iteritems()]
    # Sort by confidence desc
    result = sorted(result, key=lambda item: -item[1])
    return result

class Player(object):
    def __init__(self, name, world, strategy_cls):
        self.name = name
        self.world = world
        self.strategy = strategy_cls(self)
        self.cards = []
        self.graveyard = []
        self.protected = False

    def which_card(self):
        """Which card to play out of the 2 in our hand?"""
        # Check if we MUST play a certain card.
        c = which_card(self.cards)
        if c != -1:
            return c
        return self.strategy.which_card()

    def turn(self):
        """Draw one and discard one card."""
        if len(self.cards) == 0:
            return
        # Draw card.
        self.draw()
        # Select card to play.
        c = self.which_card()
        # Remove card from hand.
        i = self.cards.index(c)
        self.cards = self.cards[0:i] + self.cards[i + 1:len(self.cards)]
        # Add card to graveyard.
        self.graveyard.append(c)
        # Perform card action.
        log('{0} plays {1}', self.name, card_name(c))
        card_action(self, c)

    def discard(self):
        """Discard hand."""
        c = self.cards.pop()
        self.graveyard.append(c)
        log('{0} discards {1}', self.name, card_name(c))
        return c

    def draw(self):
        """Draw new card."""
        c = self.world.deck.pop()
        self.cards.append(c)
        log('{0} draws {1}', self.name, card_name(c))

    def peek(self, p2):
        """Peek at another player's hand."""
        # TODO: Do something smart.
        pass

    def __str__(self):
        hand = ', '.join(card_name(c) for c in self.cards)
        grave = ', '.join(card_name(c) for c in self.graveyard)
        return '[{0}: Hand({1}) Grave({2})]'.format(self.name, hand, grave)

class RandomStrategy(object):
    """Completely random."""

    def __init__(self, p1):
        self.p1 = p1

    def which_card(self):
        return random.choice(self.p1.cards)

    def trade_who(self):
        others = other_players(self.p1)
        if len(others) > 0:
            return random.choice(others)

    def discard_who(self):
        others = other_players(self.p1)
        if len(others) > 0:
            return random.choice(others)

    def compare_who(self):
        others = other_players(self.p1)
        if len(others) > 0:
            return random.choice(others)

    def peek_who(self):
        others = other_players(self.p1)
        if len(others) > 0:
            return others[0]

    def guess_who(self):
        others = other_players(self.p1)
        if len(others) > 0:
            return others[0]

    def guess_what(self, p2):
        # Guess random card.
        return random.randrange(8)

class SmarterGuessStrategy(RandomStrategy):
    """Random, but takes into consideration which cards have been played."""

    def guess_what(self, p2):
        possible_cards = hand_confidence(p2)
        # TODO: Weight possible cards by what hand p2 has played.
        card, confidence = possible_cards[0]
        return card

class World(object):
    def __init__(self):
        self.players = []

    def start_game(self):
        self.i = 0
        self.deck = deck()
        random.shuffle(self.deck)
        # Every player draws 1 card to start with.
        for p in self.players:
            p.draw()

    def is_game_over(self):
        # Leave at least one card unflipped in case the last card drawn is a Prince.
        return len(self.deck) <= 1 \
            or len(self.alive_players()) == 1

    def next_player(self):
        p = self.players[self.i % len(self.players)]
        self.i += 1
        return p

    def alive_players(self):
        return [p for p in self.players if len(p.cards) > 0]

    def rank_players(self):
        def key(p):
            # Sort by...
            return (
                # Player hand (weighted) desc
                -p.cards[0] * 100 if len(p.cards) > 0 else 0,
                # Graveyard sum desc
                -sum(p.graveyard)
            )
        return sorted(self.players, key=lambda p: key(p))

    def __str__(self):
        return '[Deck:{0}, {1}]'.format(len(self.deck),
            ', '.join(str(p) for p in self.players))

def new_game():
    world = World()

    p1 = Player('A', world, SmarterGuessStrategy)
    p2 = Player('B', world, RandomStrategy)
    p3 = Player('C', world, RandomStrategy)

    world.players.append(p1)
    world.players.append(p2)
    world.players.append(p3)

    world.start_game()

    while not world.is_game_over():
        p = world.next_player()
        p.turn()

    winner = world.rank_players()[0]
    log('{0} won!', winner.name)
    return winner.name

def main():
    trials = 1000
    winners = defaultdict(int)
    for i in xrange(trials):
        winner = new_game()
        winners[winner] += 1
    for w, score in winners.iteritems():
        print w, score / trials

if __name__ == '__main__':
    main()

