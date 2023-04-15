from flask import Flask, jsonify
from web3 import Web3
import json

# Set up Web3.py to connect to the local network
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Load the JobPlatform smart contract ABI
with open('JobPlatform.json') as f:
    contract_abi = json.load(f)['abi']

# Set the contract address
contract_address = '0x1234567890123456789012345678901234567890'

# Create a contract instance using the ABI and address
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# Define a Flask route to get the total number of jobs on the platform
app = Flask(__name__)

@app.route('/jobs/count')
def get_job_count():
    job_count = contract.functions.getJobCount().call()
    return jsonify({'job_count': job_count})

# Define a Flask route to add a new job to the platform
@app.route('/jobs/new')
def add_job():
    job_title = 'Software Engineer'
    job_description = 'We are looking for a skilled software engineer to join our team.'
    job_salary = 100000
    tx_hash = contract.functions.addJob(job_title, job_description, job_salary).transact()
    w3.eth.waitForTransactionReceipt(tx_hash)
    return jsonify({'status': 'success'})

if __name__ == '__main__':
    app.run()
