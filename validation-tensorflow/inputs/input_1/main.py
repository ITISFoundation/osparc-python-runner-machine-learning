import requests
import tensorflow as tf

response = requests.get("https://www.google.com")
print(response)

msg = tf.constant("Hello, TensorFlow!")
tf.print(msg)
