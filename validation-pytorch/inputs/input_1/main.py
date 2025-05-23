import torch
import os
import requests
from pathlib import Path

response = requests.get("https://www.google.com")
print(response)

msg = torch.tensor("Hello, PyTorch!")
print(msg)
# Example tensor operation
a = torch.tensor([1.0, 2.0, 3.0])
b = torch.tensor([4.0, 5.0, 6.0])
print("Sum:", a + b)


