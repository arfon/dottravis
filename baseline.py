#/usr/bin/python

""" Baseline example that needs to be beaten """

import numpy as np
import matplotlib.pyplot as plt

x, y, yerr = np.loadtxt("data/data.txt", unpack=True)

A = np.vstack((np.ones_like(x), x)).T
C = np.diag(yerr * yerr)
cov = np.linalg.inv(np.dot(A.T, np.linalg.solve(C, A)))
b_ls, m_ls = np.dot(cov, np.dot(A.T, np.linalg.solve(C, y)))

fig, ax = plt.subplots()
ax.errorbar(x, y, yerr=yerr, c="k", fmt="o")
x_range = np.array([min(x), max(x)])
ax.plot(x_range, m_ls * x_range + b_ls, c="#666666", lw=2, zorder=-100)
ax.set_xlabel("x")
ax.set_ylabel("y")
fig.savefig("assets/result.png")

print m_ls, b_ls
