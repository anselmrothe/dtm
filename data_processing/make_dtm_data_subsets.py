with open('../dtm_input_data/dtm_input-mult.dat', 'r') as f:
    mult = f.readlines()
lines = [l.strip() for l in mult]
lines = [l.split()[1:] for l in lines]
words = [[[int(n) for n in s.split(':')] for s in l] for l in lines]
with open('../dtm_input_data/dtm_input-seq.dat', 'r') as f:
    seq = f.readlines()
seq = [int(s.strip()) for s in seq][1:]


def generate_data_to_year(y):
    n_up_to_year = sum(seq[:y])
    n_including_year = sum(seq[:(y+1)])
    max_included_word = -1
    for d in words[:n_up_to_year]:
        last_word_id = d[-1][0]
        if last_word_id > max_included_word:
            max_included_word = last_word_id
    words_new = [[w for w in d if w[0] <= max_included_word]
                 for d in words[:n_including_year]]
    strings = [list_to_string(d) for d in words_new]
    with open('../dtm_input_data/dtm_input_upto_{}-mult.dat'.format(y), 'w') as f:
        f.writelines(strings[:n_up_to_year])
    with open('../dtm_input_data/dtm_input_incl_{}-mult.dat'.format(y), 'w') as f:
        f.writelines(strings)
    with open('../dtm_input_data/dtm_input_{}-seq.dat'.format(y), 'w') as f:
        strings = [str(y+1)+'\n'] + [str(n)+'\n' for n in seq[:(y+1)]]
        f.writelines(strings)


def list_to_string(l):
    s_list = [str(s[0])+':'+str(s[1]) for s in l]
    s_list = [str(len(s_list))] + s_list
    s_list = ' '.join(s_list) + '\n'
    return s_list


for y in [2, 5, 8, 11, 14, 17]:
    generate_data_to_year(y)
