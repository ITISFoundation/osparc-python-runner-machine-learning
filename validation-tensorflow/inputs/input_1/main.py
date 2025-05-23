import os

from pathlib import Path
import requests
import tensorflow as tf

response = requests.get("https://www.google.com")
print(response)

msg = tf.constant("Hello, TensorFlow!")
tf.print(msg)

(Path(os.environ["OUTPUT_FOLDER"]) / "output_1" / "a_file.txt").write_text(
    "Hello, TensorFlow!"
)
