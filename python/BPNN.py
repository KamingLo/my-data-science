import numpy as np

# Fungsi Aktivasi Sigmoid Biner
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

# Turunan Fungsi Sigmoid (untuk Backpropagation)
def sigmoid_derivative(out):
    return out * (1 - out)

# ==========================================
# 1. ARSITEKTUR & INISIALISASI
# Arsitektur: 2 Input, 2 Hidden Neuron, 1 Output Neuron
# ==========================================
X = np.array([0.8, 0.4])          # Input (x1, x2)
T = np.array([1.0])               # Target keluaran (t)
lr = 0.5                          # Laju pembelajaran (alpha)

# Bobot dari Input ke Hidden Layer (V)
# v11=0.2, v12=-0.1, v21=0.4, v22=0.3
V = np.array([[0.2, -0.1],
              [0.4,  0.3]])

# Bobot dari Hidden ke Output Layer (W)
# w1=0.5, w2=-0.2
W = np.array([0.5, -0.2]) 

# ==========================================
# 2. FASE FEEDFORWARD (Mencari Nilai Keluaran y)
# ==========================================
# Sinyal ke hidden layer (Z)
Z_in = np.dot(X, V)
Z = sigmoid(Z_in)

# Sinyal ke output layer (Y)
Y_in = np.dot(Z, W)
Y = sigmoid(Y_in)

print("--- HASIL FASE FEEDFORWARD ---")
print(f"Nilai Keluaran (Y): {Y:.4f}\n")

# ==========================================
# 3. FASE BACKPROPAGATION (Mencari Bobot Baru)
# ==========================================
# A. Menghitung Error dan Update Bobot di Output Layer (W)
delta_y = (T - Y) * sigmoid_derivative(Y)
dW = lr * delta_y * Z       # Perubahan bobot W
W_new = W + dW              # Bobot W yang baru

# B. Menghitung Error dan Update Bobot di Hidden Layer (V)
delta_z = delta_y * W * sigmoid_derivative(Z)
dV = lr * np.outer(X, delta_z) # Perubahan bobot V
V_new = V + dV                 # Bobot V yang baru

print("--- HASIL FASE BACKPROPAGATION (BOBOT BARU) ---")
print("Bobot Hidden ke Output Baru (W_new):")
print(f"w1_baru = {W_new[0]:.4f}, w2_baru = {W_new[1]:.4f}\n")

print("Bobot Input ke Hidden Baru (V_new):")
print(f"v11_baru = {V_new[0,0]:.4f}, v12_baru = {V_new[0,1]:.4f}")
print(f"v21_baru = {V_new[1,0]:.4f}, v22_baru = {V_new[1,1]:.4f}")