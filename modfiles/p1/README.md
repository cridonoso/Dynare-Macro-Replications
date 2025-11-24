# MOD Files: Real Business Cycle Models (Hansen and Wright, 1992)
## Question 1: Replication of RBC Extensions

In this question, we reproduce the five Real Business Cycle (RBC) models and their extensions presented in **Hansen and Wright (1992)**. These models are designed to assess the ability of the RBC framework to generate macroeconomic volatility consistent with empirical data (particularly the statistics in their Table 3).

---

### 1. `1.mod`: Standard RBC Model

This is the **baseline** or **canonical** RBC model. It features a representative agent with **separable preferences** over consumption and leisure, and a representative firm with a standard Cobb-Douglas production function.
* **Key Feature:** The agent's utility from consumption is independent of utility from leisure.
* **Limitation:** This model often struggles to generate sufficient volatility in labor hours compared to the volatility of output.

---

### 2. `2.mod`: Non-Separable Preferences

This extension relaxes the assumption of separable preferences by introducing a utility function where the agent's enjoyment of leisure is directly influenced by their level of consumption, or vice versa.
* **Key Feature:** Utility function is $\mathbf{U(C_t, L_t)}$, where the marginal utility of leisure depends on consumption.
* **Effect:** This interdependence strengthens the wealth effect on labor supply, helping the model generate **more volatile labor hours** and consequently higher output volatility, better matching empirical data.

---

### 3. `3.mod`: Indivisible Labor

Based on Hansen (1985) and Rogerson (1988), this model assumes that agents must choose between working a **fixed number of hours** or not working at all. The risk is shared through a competitive insurance market.
* **Key Feature:** The labor choice is **extensive** (work/don't work) rather than intensive (how many hours).
* **Effect:** This mechanism acts as a multiplier, amplifying the impact of productivity shocks on **aggregate labor supply** (the number of people working), significantly increasing the model's ability to match output and labor volatility.

---

### 4. `4.mod`: Government Spending

This extension incorporates government purchases of goods ($G_t$) into the model's resource constraint. Government spending is assumed to be **unproductive** (does not directly affect the production function) but may affect household utility or marginal costs.
* **Key Feature:** Resource Constraint includes $Y_t = C_t + I_t + G_t$. $G_t$ is typically assumed to follow an exogenous process.
* **Effect:** Government spending shocks introduce an additional source of volatility and can affect equilibrium allocations through the wealth effect (higher $G_t$ reduces wealth, increasing labor supply).

---

### 5. `5.mod`: Household Production

This model incorporates time spent on **home production** (e.g., cooking, childcare) as an alternative use of time alongside market work and leisure. The household's output is produced using market goods and household time.
* **Key Feature:** Agent allocates time $H_t$ between market work, home production, and leisure.
* **Effect:** Shocks to market productivity can induce a shift in time allocation between the market and the home sector, adding an **additional margin of substitution** that helps the model better capture the dynamics of aggregate labor and output.