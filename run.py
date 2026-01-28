#!/usr/bin/env python3
import os
from pathlib import Path
from openai import OpenAI


def main():
    client = OpenAI(
        api_key=os.environ["LITELLM_KEY"],
        base_url=os.environ["LITELLM_URL"],
    )

    try:
        response = client.chat.completions.create(
            model="claude-opus-4-5-20251101",
            messages=[
                {
                    "role": "user",
                    "content": f"Describe the fuzzing process and say hello!",
                }
            ],
        )

        print(response.choices[0].message.content)
        print()

    except Exception as e:
        print(f"\nExiting: {e}")


if __name__ == "__main__":
    main()
