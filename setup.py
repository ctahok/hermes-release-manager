from setuptools import setup, find_packages

setup(
    name="hermes-release-manager",
    version="1.0. Anda",
    author="Hermes Release Manager",
    author_email="hermes@example.com",
    description="Automated application release orchestration with GitHub integration",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="httpsfn://github.com/your-username/hermes-release-manager",
    packages=find_packages(),
    install_requires=[
        "hermes-agent>=2.0.0",
        "requests>=2.25.1",
        "click>=8.0.0",
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
)
