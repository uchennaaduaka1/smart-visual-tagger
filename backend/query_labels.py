import boto3

def get_image_labels(image_name):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('ImageLabels')

    response = table.get_item(Key={'image': image_name})
    
    if 'Item' in response:
        return response['Item']['labels']
    else:
        return "No labels found for this image."

if __name__ == "__main__":
    image_name = "test2.jpg"  # Replace with your image file name
    labels = get_image_labels(image_name)
    print(f"Labels for {image_name}: {labels}")
