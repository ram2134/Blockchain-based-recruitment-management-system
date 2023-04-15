// import "./App.css";
// import artifacto from "./artifacts/contracts/JobPlatform.sol/JobPlatform.json";
// function App() {
//   const Web3 = require("web3");
//   const web3 = new Web3("http://127.0.0.1:8545/"); // replace with your own provider
//   const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // replace with your deployed contract address
//   const abi = artifacto.abi;
//   const jobPlatform = new web3.eth.Contract(abi, contractAddress);

//   async function createCandidateProfile(name, email, resumeHash) {
//     const accounts = await web3.eth.getAccounts();
//     await jobPlatform.methods
//       .createCandidateProfile(name, email, resumeHash)
//       .send({ from: accounts[0] });
//     console;
//   }
//   async function getCandidateProfile(candidateAddress) {
//     const candidate = await jobPlatform.methods
//       .candidates(candidateAddress)
//       .call();
//     console.log(candidate);
//   }
//   return (
//     <div className="App">
//       <div>Ram Chandra</div>
//       <button
//         onClick={() =>
//           createCandidateProfile("vamshi", "vamshi@email", "kjbbdfjkbsdkfbskdf")
//         }
//       >
//         Create Candidate Profile{" "}
//       </button>
//     </div>
//   );
// }

// export default App;

import React, { useState, useEffect } from "react";
import JobPosting from "./Components/JobPosting";
import CreateJobPostingForm from "./Components/CreateJobPostingForm";
import { ethers } from "ethers";
import JobPlatformABI from "./artifacts/contracts/JobPlatform.sol/JobPlatform.json";
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();
const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const contract = new ethers.Contract(
  contractAddress,
  JobPlatformABI.abi,
  signer
);

function App() {
  const [userAddress, setUserAddress] = useState("");
  const [userType, setUserType] = useState("");
  const [jobPostings, setJobPostings] = useState([]);
  const [showCreateJobPostingForm, setShowCreateJobPostingForm] =
    useState(false);
  const [showCreateCandidateProfileForm, setShowCreateCandidateProfileForm] =
    useState(false);
  const [showCreateCompanyProfileForm, setShowCreateCompanyProfileForm] =
    useState(false);
  const [candidateName, setCandidateName] = useState("");
  const [candidateEmail, setCandidateEmail] = useState("");
  const [candidateResumeHash, setCandidateResumeHash] = useState("");
  const [companyName, setCompanyName] = useState("");
  const [companyEmail, setCompanyEmail] = useState("");
  const [companyIndustry, setCompanyIndustry] = useState("");

  useEffect(() => {
    async function fetchData() {
      const address = await signer.getAddress();
      setUserAddress(address);

      const isCandidate = await contract.candidates(address);
      if (isCandidate.account !== ethers.constants.AddressZero) {
        setUserType("candidate");
      } else {
        const isCompany = await contract.companies(address);
        if (isCompany.account !== ethers.constants.AddressZero) {
          setUserType("company");
        }
      }
    }

    fetchData();
  }, []);

  useEffect(() => {
    async function fetchData() {
      const jobPostingIds = await contract.getLastJobPostingIds();

      const postings = [];
      for (let i = 0; i < jobPostingIds.length; i++) {
        const jobPosting = await contract.jobPostings(jobPostingIds[i]);
        const company = await contract.companies(jobPosting.owner);

        postings.push({
          id: jobPosting.id,
          title: jobPosting.title,
          description: jobPosting.description,
          company: company.name,
          numApplications: jobPosting.numApplications.toNumber(),
        });
      }

      setJobPostings(postings);
    }

    fetchData();
  }, []);

  async function createJobPosting(title, description) {
    await contract.createJobPosting(title, description);
    setShowCreateJobPostingForm(false);
    window.location.reload();
  }

  async function deleteJobPosting(id) {
    await contract.deleteJobPosting(id);
    window.location.reload();
  }
  async function createCandidateProfile() {
    await contract.createCandidateProfile(
      candidateName,
      candidateEmail,
      candidateResumeHash
    );
    setShowCreateCandidateProfileForm(false);
    window.location.reload();
  }

  async function createCompanyProfile() {
    await contract.createCompanyProfile(
      companyName,
      companyEmail,
      companyIndustry
    );
    setShowCreateCompanyProfileForm(false);
    window.location.reload();
  }

  function renderJobPostings() {
    return jobPostings.map((posting) => (
      <JobPosting
        key={posting.id}
        id={posting.id}
        title={posting.title}
        description={posting.description}
        company={posting.company}
        numApplications={posting.numApplications}
        userType={userType}
        onDelete={deleteJobPosting}
      />
    ));
  }

  function renderCreateJobPostingForm() {
    if (showCreateJobPostingForm) {
      return <CreateJobPostingForm onCreate={createJobPosting} />;
    }

    return (
      <button onClick={() => setShowCreateJobPostingForm(true)}>
        Create Job Posting
      </button>
    );
  }
  return (
    <div>
      <h1>Job Platform</h1>
      <h2>Welcome, {userType === "candidate" ? "Candidate" : "Company"}</h2>

      {userType === "candidate" && (
        <div>
          <h3>Create Candidate Profile</h3>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              createCandidateProfile(
                candidateName,
                candidateEmail,
                candidateResumeHash
              );
            }}
          >
            <label>Name:</label>
            <input
              type="text"
              value={candidateName}
              onChange={(e) => setCandidateName(e.target.value)}
            />
            <br />
            <label>Email:</label>
            <input
              type="email"
              value={candidateEmail}
              onChange={(e) => setCandidateEmail(e.target.value)}
            />
            <br />
            <label>Resume Hash:</label>
            <input
              type="text"
              value={candidateResumeHash}
              onChange={(e) => setCandidateResumeHash(e.target.value)}
            />
            <br />
            <button type="submit">Create Profile</button>
          </form>
        </div>
      )}
      {userType === "company" && (
        <div>
          <h3>Create Company Profile</h3>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              createCompanyProfile(companyName, companyEmail);
            }}
          >
            <label>Name:</label>
            <input
              type="text"
              value={companyName}
              onChange={(e) => setCompanyName(e.target.value)}
            />
            <br />
            <label>Email:</label>
            <input
              type="email"
              value={companyEmail}
              onChange={(e) => setCompanyEmail(e.target.value)}
            />
            <br />
            <label>Industry:</label>
            <input
              type="text"
              value={companyIndustry}
              onChange={(e) => setCompanyIndustry(e.target.value)}
            />
            <br />
            <button type="submit">Create Profile</button>
          </form>
        </div>
      )}

      {renderCreateJobPostingForm()}
      {renderJobPostings()}
    </div>
  );
}

export default App;
