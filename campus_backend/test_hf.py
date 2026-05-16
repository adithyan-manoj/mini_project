import requests
import socket

try:
    print(f"Resolving huggingface.co: {socket.getaddrinfo('huggingface.co', 443)}")
    response = requests.head("https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/main/adapter_config.json")
    print(f"Hugging Face connectivity test: {response.status_code}")
except Exception as e:
    print(f"Error: {e}")
