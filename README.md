# Smart Visual Tagger – Serverless Image Labeling Pipeline

## Overview

**Smart Visual Tagger** is a serverless AWS architecture that automatically tags uploaded images using machine learning and stores metadata for future querying.

Built entirely with:
- **AWS S3** – image storage
- **AWS Lambda** – event-driven processing
- **Amazon Rekognition** – ML labeling
- **AWS DynamoDB** – metadata storage
- **Terraform** – infrastructure as code
- **Python** – backend logic

---

## Architecture

```plaintext
[S3 Bucket (Image Uploads)]
          ↓ (S3 Event Trigger)
[AWS Lambda Function (Python 3.13)]
          ↓
[Amazon Rekognition (Label Detection)]
          ↓
[AWS DynamoDB Table (Image Labels Storage)]
```

---

## Features

- Upload any `.jpg` image to S3.
- Lambda automatically triggers and analyzes the image with Rekognition.
- Detected labels (tags) are stored in DynamoDB associated with the image filename.
- Infrastructure is fully managed with Terraform.
- Lambda includes retry logic for eventual consistency on S3 object metadata.

---

## Setup Instructions

### 1. Deploy Infrastructure

- Clone this repository
- Navigate to the `terraform/` directory
- Run:

```bash
terraform init
terraform apply
```

This deploys:
- S3 bucket
- Lambda function
- IAM roles and permissions
- DynamoDB table

---

### 2. Upload an Image

Upload a test image to the S3 bucket:

```bash
aws s3 cp path/to/test.jpg s3://smart-visual-tagger-images/ --acl public-read
```

_Note: If Block Public ACLs are enabled, ensure correct permissions before upload._

---

### 3. Check CloudWatch Logs

Tail Lambda logs to verify Rekognition output:

```bash
aws logs tail /aws/lambda/image_tag_lambda --follow
```

Example output:

```plaintext
Labels for test.jpg: ['Person', 'Shoe', 'Female', 'Smile']
```

---

### 4. Query DynamoDB for Tags

Use the provided `query_labels.py` to fetch labels:

```bash
python3 query_labels.py
```

Example output:

```plaintext
Labels for test.jpg: ['Person', 'Shoe', 'Female', 'Smile']
```

---

## Project Structure

```plaintext
terraform/
├── main.tf         # Entry point for Terraform modules
├── s3.tf           # S3 bucket and bucket policy
├── lambda.tf       # Lambda function definition
├── iam.tf          # IAM roles and permissions
├── dynamodb.tf     # DynamoDB table

backend/
├── app.py          # Lambda source code
├── image_lambda.zip # Zipped Lambda deployment package

query_labels.py      # Script to query DynamoDB
README.md            # Project Documentation
```

---

## Technologies Used

- **AWS S3**
- **AWS Lambda (Python 3.13)**
- **AWS DynamoDB**
- **Amazon Rekognition**
- **AWS IAM**
- **Terraform**
- **Python 3**

---

## Future Enhancements

- Build a Streamlit or React frontend to search tags visually
- Integrate OpenSearch for semantic image search
- Add support for bulk image processing
- Secure S3 bucket with signed URL uploads instead of public ACLs
- Add Lambda Dead Letter Queue (DLQ) for failed events

---

## Author

Backend Engineering by Uchenna Aduaka 
Built with 💻, ☁️, and 🧠.

---

# Commands.md

## Terraform Commands

```bash
# Initialize Terraform (only once per machine or repo)
terraform init

# Apply the Terraform plan and create/update AWS resources
terraform apply

# Force replace a resource (useful if stuck)
terraform taint aws_s3_bucket_policy.allow_rekognition_access
terraform apply

# Preview changes before applying
terraform plan
```

## AWS CLI Commands

```bash
# Upload an image to S3 with public-read ACL (if ACLs are allowed)
aws s3 cp path/to/test.jpg s3://smart-visual-tagger-images/ --acl public-read

# Tail Lambda logs in real-time
aws logs tail /aws/lambda/image_tag_lambda --follow

# Check objects inside your S3 bucket
aws s3 ls s3://smart-visual-tagger-images/
```

## Python Commands

```bash
# Re-zip updated Lambda function code
cd backend
zip image_lambda.zip app.py

# Query DynamoDB for a specific image
python3 query_labels.py
```

---
