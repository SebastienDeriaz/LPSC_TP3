# LPSC_TP3
 


## Présentation 12.04.2022

Au maximum on a une fenêtre de -1.5 à 0.5 sur l'axe des nombres réels et -1 à 1 sur l'axe imaginaire. Ensuite on va essayer de zoomer au maximum avec la précision qu'on utilisera
$$\huge \boxed{z_{n+1}=z_n^2 + c}$$

$$z_{n+1}=(z_{n_r}+jz_{n_i})^2 + c_r + jc_i$$

$$z_{n+1}=z_{n_r}^2 - z_{n_i}^2 + 2jz_{n_r}z_{n_i} + c_r + jc_i$$

$$\Large \begin{cases}
z_{n+1_{r}} &= z_{n_r}^2 - z_{n_i}^2 + c_r\\
z_{n+1_{i}} &= 2z_{n_r}z_{n_i} + c_i
\end{cases}$$

