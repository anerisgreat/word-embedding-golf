from src import WordToVecGame

g = WordToVecGame()
g.init_game()
while(not g.get_game_done()):
    print(f'Target is {g.get_dest()}. Current word is: {g.get_current()}')
    # current_similarity = g.get_current_similarity()
    neighbor_str = ', '.join(g.get_neighbors())
    print(f'Current neighbors are: {neighbor_str}')
    k = input(f'Enter word: ')
    valid, msg = g.guess(k)
    if(valid):
        # new_similarity = g.get_current_similarity()
        # if(new_similarity > current_similarity):
            # print(f'Similarity improved by {new_similarity - current_similarity}')
        # else:
            # print(f'Wrong way by {current_similarity - new_similarity}')
        pass
    else:
        print(msg)
