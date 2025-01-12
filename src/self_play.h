// self_play.h

#ifndef SELF_PLAY_H_INCLUDED
#define SELF_PLAY_H_INCLUDED

struct SelfPlayStats
{
    int totalGames;
    int whiteWins;
    int blackWins;
    int draws;
};

extern SelfPlayStats g_stats;

int playOneGame(); // Returns the result (0=draw, 1=white wins, 2=black wins)

#endif // SELF_PLAY_H_INCLUDED
