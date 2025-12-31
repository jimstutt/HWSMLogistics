#!/bin/bash
set -e
echo "🚀 Deploying application..."
cd ~/Dev/NGOL-D
./deploy-prod.sh
echo "✅ Deployment completed successfully"
echo "💡 Access the application at: http://localhost"
