#/usr/bin/python

""" Submission """
 
import os
import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as op

import emcee

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
result = op.minimize(nll, [m_ls, b_ls, np.log(0.534)], args=(x, y, yerr))
m_ml, b_ml, lnf_ml = result["x"]


def lnprior(theta):
    m, b, lnf = theta
    if -5.0 < m < 0.5 and 0.0 < b < 10.0 and -10.0 < lnf < 1.0:
        return 0.0
    return -np.inf

def lnprob(theta, x, y, yerr):
    lp = lnprior(theta)
    if not np.isfinite(lp):
        return -np.inf
    return lp + lnlike(theta, x, y, yerr)



ndim, nwalkers = 3, 100
pos = [result["x"] + 1e-4*np.random.randn(ndim) for i in range(nwalkers)]


sampler = emcee.EnsembleSampler(nwalkers, ndim, lnprob, args=(x, y, yerr))

sampler.run_mcmc(pos, 500)

samples = sampler.chain[:, 50:, :].reshape((-1, ndim))


fig, ax = plt.subplots()

xl = np.array([min(x), max(x)])
for m, b, lnf in samples[np.random.randint(len(samples), size=100)]:
    ax.plot(xl, m*xl+b, color="k", alpha=0.1)
#ax.plot(xl, m_true*xl+b_true, color="r", lw=3, alpha=0.8)
ax.errorbar(x, y, yerr=yerr, fmt=".k")

ax.set_xlabel("x")
ax.set_ylabel("y")
fig.savefig("assets/result.png")

samples[:, 2] = np.exp(samples[:, 2])
m_mcmc, b_mcmc, f_mcmc = map(lambda v: (v[1], v[2]-v[1], v[1]-v[0]),
                             zip(*np.percentile(samples, [16, 50, 84],
                                                axis=0)))


print("Results of m, b: ({0:.4f}, {1:.4f})".format(m_mcmc[0], b_mcmc[0]))


# Let's store result parameters in environment variables, and we will deal
# with more complex values (e.g., uncertainties, etc) later
with open("result.csv", "w") as fp:
    fp.write("{0:.5f},{1:.5f}".format(m_mcmc[0], b_mcmc[0]))
