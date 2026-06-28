# LaTeX Math Typesetting Guide

Comprehensive guide for mathematical typesetting in LaTeX.

## Required Packages

```latex
\usepackage{amsmath}    % Advanced math environments
\usepackage{amssymb}    % Additional symbols
\usepackage{mathtools}  % Extensions to amsmath
```

## Inline Math

```latex
The quadratic formula is $x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}$.

Inline math like $E = mc^2$ appears within text.
```

## Displayed Equations

### Simple Equation
```latex
\begin{equation}
f(x) = ax^2 + bx + c
\end{equation}
```

### Equation with Label
```latex
\begin{equation}
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
\label{eq:gaussian}
\end{equation}
```

Reference with: `\eqref{eq:gaussian}`

### Multi-Line Equations (Align)
```latex
\begin{align}
f(x) &= (x+1)^2 \\
     &= x^2 + 2x + 1
\end{align}
```

### Multiple Equations with Alignment
```latex
\begin{align}
a &= b + c \\
  &= d + e + f \\
  &= g
\end{align}
```

### Equation Cases
```latex
f(x) = 
\begin{cases}
x^2 & \text{if } x \geq 0 \\
-x^2 & \text{if } x < 0
\end{cases}
```

## Common Symbols

### Greek Letters
```latex
\alpha, \beta, \gamma, \delta, \epsilon, \varepsilon
\theta, \vartheta, \iota, \kappa, \lambda, \mu
\nu, \xi, \pi, \varpi, \rho, \varrho
\sigma, \varsigma, \tau, \upsilon, \phi, \varphi
\chi, \psi, \omega

% Capital Greek
\Gamma, \Delta, \Theta, \Lambda, \Xi, \Pi
\Sigma, \Upsilon, \Phi, \Psi, \Omega
```

### Operators
```latex
\pm, \mp, \times, \div, \cdot, \ast, \star
\leq, \geq, \neq, \approx, \equiv, \sim
\subset, \supset, \in, \notin, \cup, \cap
\partial, \nabla, \sum, \prod, \int
\lim, \inf, \sup, \max, \min
```

### Relations
```latex
\rightarrow, \Rightarrow, \leftarrow, \Leftarrow
\leftrightarrow, \Leftrightarrow
\mapsto, \hookleftarrow
\oplus, \otimes, \ominus
```

### Arrows with Text
```latex
\xrightarrow{\text{label}}
\overset{\text{text}}{\rightarrow}
\underset{\text{text}}{\rightarrow}
```

## Matrices

### Basic Matrix Environment
```latex
\begin{matrix}
a & b \\
c & d
\end{matrix}
```

### Brackets
```latex
\begin{bmatrix}
a_{11} & a_{12} \\
a_{21} & a_{22}
\end{bmatrix}
```

### Parentheses
```latex
\begin{pmatrix}
x \\
y
\end{pmatrix}
```

### Determinant (Vertical Bars)
```latex
\begin{vmatrix}
a & b \\
c & d
\end{vmatrix}
```

### Dots
```latex
\begin{bmatrix}
a_{11} & \dots & a_{1n} \\
\vdots & \ddots & \vdots \\
a_{m1} & \dots & a_{mn}
\end{bmatrix}
```

### Augmented Matrix
```latex
\left[\begin{array}{cccc|c}
a_{11} & a_{12} & \dots & a_{1n} & b_1 \\
a_{21} & a_{22} & \dots & a_{2n} & b_2 \\
\vdots & \vdots & \ddots & \vdots & \vdots \\
a_{m1} & a_{m2} & \dots & a_{mn} & b_m
\end{array}\right]
```

## Theorems and Proofs

### Define Theorem Environment
```latex
\newtheorem{theorem}{Theorem}
\newtheorem{definition}{Definition}
\newtheorem{lemma}{Lemma}

% amsthm already provides a proof environment:
% \begin{proof} ... \end{proof}
```

### Theorem Example
```latex
\begin{theorem}
Let $f$ be a continuous function on $[a,b]$. Then...
\end{theorem}
```

### Proof Example
```latex
\begin{proof}
Let $x$ be any element of the set. 
Since $x$ satisfies property $P$, we have...
Therefore, the theorem holds.
\end{proof}
```

### QED Symbol
```latex
\begin{proof}
[proof content]
\end{proof}
```

The QED symbol is added automatically at the end of a `proof` environment.

## Numbering

### Sub-Numbering (subequations)
```latex
\begin{subequations}
\begin{align}
a &= b \label{eq:1a}\\
c &= d \label{eq:1b}
\end{align}
\end{subequations}
```

### Remove Numbering
```latex
\begin{equation*}
content without number
\end{equation*}
```

### Manual Numbering
```latex
\begin{equation}
x = y \tag{custom}
\end{equation}
```

## Fractions and Roots

```latex
\frac{a}{b}          % Fraction
\sqrt{x}             % Square root
\sqrt[n]{x}          % nth root
\frac{\frac{a}{b}}{\frac{c}{d}}  % Nested fraction
```

## Limits, Sums, Integrals

```latex
\lim_{x \to \infty} f(x)
\sum_{i=1}^{n} x_i
\prod_{i=1}^{n} x_i
\int_{a}^{b} f(x) dx
\oint_{C} F \cdot ds
\iint_{D} f(x,y) dA
\iiint_{V} f(x,y,z) dV
```

## Fonts in Math Mode

```latex
\mathrm{roman}      % Upright
\mathbf{bold}       % Bold
\mathcal{calligraphy}  % Calligraphy
\mathsf{sans-serif}    % Sans-serif
\mathit{italic}        % Italic
\mathbb{blackboard}   % Blackboard bold (requires amssymb)
\mathfrak{fraktur}    % Fraktur (requires amssymb)
```

## Common Mathematical Expressions

### Summation
```latex
\sum_{i=1}^{\infty} \frac{1}{i^2} = \frac{\pi^2}{6}
```

### Product
```latex
\prod_{i=1}^{n} i = n!
```

### Binomial
```latex
\binom{n}{k} = \frac{n!}{k!(n-k)!}
```

### Norm
```latex
\|x\|_2 = \sqrt{\sum_{i=1}^{n} x_i^2}
```

Or: `\lVert x \rVert`

### Set Notation
```latex
\{ x \in \mathbb{R} \mid x > 0 \}
\setminus, \subset, \supseteq
```

### Logic Symbols
```latex
\forall, \exists, \neg, \land, \lor
\implies, \iff, \therefore, \because
```

## Tips

1. **Both `$...$` and `\(...\)` are valid** for inline math; `\(...\)` is recommended in large documents for better error localization
2. **Use `align` for multi-line** equations (not `eqnarray`)
3. **Reference with `\eqref{name}`** for equation references
4. **Use `\text{...}`** for text within math mode
5. **Load `mathtools`** for additional features like `multlined`

## IEEE Specific

IEEE papers can use `IEEEeqnarray` for displayed equations (preferred over `eqnarray`):

```latex
\begin{IEEEeqnarray}{rCl}
f(x) &=& (x+1)^2 \\
     &=& x^2 + 2x + 1
\end{IEEEeqnarray}
```

Requires: `\usepackage[retainorgcmds]{IEEEtrantools}`
