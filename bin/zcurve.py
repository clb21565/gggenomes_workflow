import matplotlib.pyplot as plt

from mpl_toolkits.mplot3d import Axes3D

from Bio import SeqIO

import pandas as pd



def compute_z_curve(sequence):

    x, y, z = [0], [0], [0]

    

    for base in sequence.upper():

        x.append(x[-1] + (1 if base in "AG" else -1))

        y.append(y[-1] + (1 if base in "AC" else -1))

        z.append(z[-1] + (1 if base in "GC" else -1))

    

    return x, y, z



def process_fasta(file_path):

    results = []

    

    for record in SeqIO.parse(file_path, "fasta"):

        x, y, z = compute_z_curve(str(record.seq))

        for i in range(len(x)):

            results.append({

                "ID": record.id,

                "Position": i,

                "X": x[i],

                "Y": y[i],

                "Z": z[i]

            })

    

    return pd.DataFrame(results)



if __name__ == "__main__":

    fasta_file = "sampled-complete-mfds.fasta"  # Replace with your file path

    df = process_fasta(fasta_file)

    df.to_csv("z_curve_results.csv", index=False)

    print(df)
