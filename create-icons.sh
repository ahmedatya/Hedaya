#!/bin/bash

# Simple script to create icons - tries different Python versions

echo "🎨 Generating Hedaya app icons..."
echo ""

# Try different Python versions (python3.10 first since that's where Pillow is usually installed)
for PYTHON in python3.10 python3.11 python3.12 python3; do
    if command -v $PYTHON &> /dev/null; then
        echo "Trying $PYTHON..."
        if $PYTHON -c "from PIL import Image" 2>/dev/null; then
            echo "✓ Found working Python with Pillow: $PYTHON"
            echo ""
            $PYTHON generate-icon.py
            if [ $? -eq 0 ]; then
                echo ""
                echo "✅ Icons generated successfully!"
                exit 0
            fi
        fi
    fi
done

echo "❌ Could not find Python with Pillow installed"
echo ""
echo "Please run manually:"
echo "  python3.10 generate-icon.py"
echo ""
echo "Or install Pillow for your Python version:"
echo "  pip3 install Pillow"
