#/usr/bin/python

""" Optimised example """

import numpy as np
import scipy.optimize as op
import matplotlib.pyplot as plt

x, y, yerr = np.loadtxt("data/data.txt", unpack=True)

A = np.vstack((np.ones_like(x), x)).T
C = np.diag(yerr * yerr)
cov = np.linalg.inv(np.dot(A.T, np.linalg.solve(C, A)))
b_ls, m_ls = np.dot(cov, np.dot(A.T, np.linalg.solve(C, y)))

def lnlike(theta, x, y, yerr):
    m, b, lnf = theta
    model = m * x + b
    inv_sigma2 = 1.0/(yerr**2 + model**2*np.exp(2*lnf))
    return -0.5*(np.sum((y-model)**2*inv_sigma2 - np.log(inv_sigma2)))


nll = lambda *args: -lnlike(*args)
result = op.minimize(nll, [m_true, b_true, np.log(f_true)], args=(x, y, yerr))
m_ml, b_ml, lnf_ml = result["x"]

m_ls, b_ls = m_ml, b_ml

fig, ax = plt.subplots()
ax.errorbar(x, y, yerr=yerr, c="k", fmt="o")
x_range = np.array([min(x), max(x)])
ax.plot(x_range, m_ls * x_range + b_ls, c="#666666", lw=2, zorder=-100)
ax.set_xlabel("x")
ax.set_ylabel("y")
fig.savefig("assets/result.png")

print("Results of m, b: ({0:.4f} {1:.4f})".format(m_ls, b_ls))

# Let's store result parameters in environment variables, and we will deal
# with more complex values (e.g., uncertainties, etc) later
with open("result.csv", "w") as fp:
    fp.write("{0:.5f},{1:.5f}".format(m_ls, b_ls))
