from dotenv import load_dotenv
from datetime import datetime 
from minio import Minio

load_dotenv()

DEVICE_ID = os.getenv("DEVICE_ID")
client = Minio(
  os.getenv("IP") + ":9000",
  access_key=os.getenv("MINIO_ROOT_USER"),
  secret_key=os.getenv("MINIO_ROOT_PASSWORD"),
  secure=False
) 
capture_filename = os.getenv("CAPTURE_FILENAME")
print(f"Checking Connection: {client.bucket_exists("radar-data")}")

print(f"Ready to Upload: {capture_filename}")

try:
      folder = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
      
      client.fput_object(
        bucket_name=os.getenv("BUCKET_NAME"),
        object_name=f"{DEVICE_ID}/{folder}/capture.bin",
        file_path=capture_filename
      )

      print("Upload Completed Successfully!")
    
except Exception as e:
      print(f"Error Occurred While Uploading: {e}")
