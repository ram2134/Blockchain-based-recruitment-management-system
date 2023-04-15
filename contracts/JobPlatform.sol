// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

contract JobPlatform {
    uint256 constant MAX_JOB_POSTINGS = 10;
    uint256 constant MAX_JOB_APPLICATIONS = 10;

    mapping(address => Candidate) public candidates;
    mapping(address => Company) public companies;
    mapping(uint256 => JobPosting) public jobPostings;
    event JobPostingDeleted(uint256 jobPostingId, address owner);
    event NewJobPosting(uint256 jobPostingId, address owner);



 
    struct Candidate {
        address account;
        string name;
        string email;
        string resumeHash;
        uint256 numApplications;
        mapping(uint256 => uint256) appliedJobPostings; // jobPostingId => timestamp
        mapping(address => bool) appliedCompanies; // companyAddress => hasApplied
        mapping(address => uint256) interestedCompanies; // companyId => timestamp
    }

    struct Company {
        uint256 numJobPostings;
        address account;
        string name;
        string email;
        string industry;
        mapping(uint256 => uint256) jobPostings; // jobPostingId => timestamp
    }

    struct JobPosting {
        uint256 id;
        address owner;
        string title;
        string description;
        uint256 salary;
        uint256 creationTimestamp;
        uint256 numApplications;
        mapping(address => uint256) appliedCandidates; // candidateId => timestamp
    }

    uint256 public lastJobPostingId;
    event countofjobs(uint256 lastJobPostingId);
    function getCount() public{
        emit countofjobs(lastJobPostingId);
    }
  


    function createCandidateProfile(string memory _name, string memory _email, string memory _resumeHash) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        require(bytes(_resumeHash).length > 0, "Resume hash cannot be empty");
        
        Candidate storage candidate = candidates[msg.sender];
        candidate.account = msg.sender;
        candidate.name = _name;
        candidate.email = _email;
        candidate.resumeHash = _resumeHash;
        candidate.numApplications=0;
    }

    function deleteCandidateProfile() public {
        Candidate storage candidate = candidates[msg.sender];
        require(msg.sender ==candidate.account, "Only the owner can update the profile");
        delete candidates[msg.sender];
    }
    function getCandidateProfile(address _candidateAddress) public view returns (string memory, string memory, string memory, uint256) {
        Candidate storage candidate = candidates[_candidateAddress];
        require(candidate.account == _candidateAddress, "Candidate profile does not exist");
        return (candidate.name, candidate.email, candidate.resumeHash, candidate.numApplications);
    }

    function createCompanyProfile(string memory _name, string memory _email,string memory _industry) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        // require(bytes(_phoneNumber).length > 0, "Phone number cannot be empty");
        require(bytes(_industry).length > 0, "Industry cannot be empty");        
        Company storage company = companies[msg.sender];
        company.numJobPostings=0;
        company.account = msg.sender;
        company.name = _name;
        company.email = _email;
        // company.phoneNumber = _phoneNumber;
        company.industry = _industry;
        company.numJobPostings=0;

    }

    function deleteCompanyProfile() public {
        Company storage company = companies[msg.sender];
        require(msg.sender ==company.account, "Only the owner can update the company profile");  
        delete companies[msg.sender];
    }
    function getCompanyProfile(address _companyAddress) public view returns (string memory companyName, string memory email,string memory industry,uint256 numJobPostings) {
        companyName = companies[_companyAddress].name;
        email = companies[_companyAddress].email;
        // phoneNumber = companies[_companyAddress].phoneNumber;
        industry = companies[_companyAddress].industry;
        numJobPostings=companies[_companyAddress].numJobPostings;
        return (companyName, email,industry,numJobPostings);
    }

    function createJobPosting(string memory _title, string memory _description,uint256 sal) public {
        Company storage company = companies[msg.sender];
        require(company.account == msg.sender, "Only the owner can create job postings");
        require(company.numJobPostings < MAX_JOB_POSTINGS, "Maximum number of job postings reached");
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");

        lastJobPostingId++;
        uint256 newJobPostingId = lastJobPostingId;
        company.numJobPostings++;
        company.jobPostings[newJobPostingId] = block.timestamp;

        JobPosting storage job  = jobPostings[newJobPostingId];
        job.id=newJobPostingId;
        job.owner=msg.sender;
        job.title=_title;
        job.description=_description;
        job.salary=sal;
        job.creationTimestamp=block.timestamp;
        job.numApplications=0;

        // Notify interested candidates about new job posting
        for (uint256 i = 1; i <= lastJobPostingId; i++) {
            if (candidates[msg.sender].interestedCompanies[companies[jobPostings[i].owner].account] > 0 && i != newJobPostingId) {
                emit NewJobPosting(i, msg.sender);
            }
        }
        
    }

    function deleteJobPosting(uint256 _jobPostingId) public {
        JobPosting storage jobPosting = jobPostings[_jobPostingId];
        require(jobPosting.owner == msg.sender, "Only the owner can delete job postings");
        require(jobPosting.numApplications == 0, "Cannot delete job posting with active applications");

        Company storage company = companies[msg.sender];
        require(company.jobPostings[_jobPostingId] > 0, "Job posting does not exist");

        company.numJobPostings--;
        delete company.jobPostings[_jobPostingId];
        delete jobPostings[_jobPostingId];
        emit JobPostingDeleted(_jobPostingId, msg.sender);
    }

    function updateJobPosting(uint256 _jobPostingId, string memory _title, string memory _description) public {
        JobPosting storage jobPosting = jobPostings[_jobPostingId];
        require(jobPosting.owner == msg.sender, "Only the owner can update job postings");
        require(jobPosting.numApplications == 0, "Cannot update job posting with active applications");
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");

        jobPosting.title = _title;
        jobPosting.description = _description;
    }
    function getJobPostingDetails(uint256 _jobPostingId) public view returns (uint256 id, address owner, string memory title, string memory description, uint256 creationTimestamp, uint256 numApplications) {
        JobPosting storage jobPosting = jobPostings[_jobPostingId];
        require(jobPosting.id == _jobPostingId, "Job posting does not exist");

        return (
            jobPosting.id,
            jobPosting.owner,
            jobPosting.title,
            jobPosting.description,
            jobPosting.creationTimestamp,
            jobPosting.numApplications
        );
    }
    function applyToJobPosting1(uint256 _jobPostingId) public {
        require(candidates[msg.sender].account == msg.sender, "Only candidates can apply to job postings");
        require(candidates[msg.sender].numApplications < MAX_JOB_APPLICATIONS, "Maximum number of job applications reached");

        JobPosting storage jobPosting = jobPostings[_jobPostingId];
        require(jobPosting.id > 0, "Job posting does not exist");
        require(jobPosting.appliedCandidates[candidates[msg.sender].account] == 0, "Candidate has already applied to this job posting");

        Company storage company = companies[jobPosting.owner];
        require(company.account != msg.sender, "Candidates cannot apply to their own company's job postings");

        jobPosting.numApplications++;
        jobPosting.appliedCandidates[candidates[msg.sender].account] = block.timestamp;

        Candidate storage candidate = candidates[msg.sender];
        candidate.numApplications++;
        candidate.appliedJobPostings[_jobPostingId] = block.timestamp;
    }
    bytes32 candhash;
    string jobname;
    event applied(bytes32 candhash,string  jobname);

    function applyToJobPosting(bytes32 candidatehash,string memory jobtitle) public{
            candhash = candidatehash;
            jobname=jobtitle;
            emit applied(candhash,jobname);


    }

    function withdrawJobApplication(uint256 _jobPostingId) public {
        require(candidates[msg.sender].account == msg.sender, "Only candidates can withdraw job applications");

        JobPosting storage jobPosting = jobPostings[_jobPostingId];
        require(jobPosting.id > 0, "Job posting does not exist");
        require(jobPosting.appliedCandidates[candidates[msg.sender].account] > 0, "Candidate has not applied to this job posting");

        jobPosting.numApplications--;
        delete jobPosting.appliedCandidates[candidates[msg.sender].account];

        Candidate storage candidate = candidates[msg.sender];
        candidate.numApplications--;
        delete candidate.appliedJobPostings[_jobPostingId];
    }

    function getAppliedJobPostings() public view returns (uint256[] memory) {
        Candidate storage candidate = candidates[msg.sender];
        uint256[] memory jobPostingIds = new uint256[](candidate.numApplications);

        uint256 counter = 0;
        for (uint256 i = 1; i <= lastJobPostingId; i++) {
            if (jobPostings[i].id == 0) {
                continue;
            }
            if (jobPostings[i].appliedCandidates[candidate.account] > 0) {
                jobPostingIds[counter] = jobPostings[i].id;
                counter++;
            }
        }

        return jobPostingIds;
    }

    function getCompanyJobPostings(address _companyAddress) public view returns (uint256[] memory) {
        Company storage company = companies[_companyAddress];
        uint256[] memory jobPostingIds = new uint256[](company.numJobPostings);

        uint256 counter = 0;
        for (uint256 i = 1; i <= lastJobPostingId; i++) {
            if (jobPostings[i].id == 0) {
                continue;
            }
            if (jobPostings[i].owner == _companyAddress) {
                jobPostingIds[counter] = jobPostings[i].id;
                counter++;
            }
        }

        return jobPostingIds;
    }



    function getCompanyJobPostingDetails(address _companyAddress, uint256 _jobPostingId) public view returns (uint256 id, string memory title, string memory description, uint256 creationTimestamp, uint256 numApplications) {
        Company storage company = companies[_companyAddress];
        require(company.jobPostings[_jobPostingId] > 0, "Job posting does not exist or is not owned by the company");

        JobPosting storage jobPosting = jobPostings[_jobPostingId];
        return (
            jobPosting.id,
            jobPosting.title,
            jobPosting.description,
            jobPosting.creationTimestamp,
            jobPosting.numApplications
        );
    }
    function getCompanyDetails(address _companyAddress) public view returns (string memory name, uint256 numJobPostings) {
        Company storage company = companies[_companyAddress];
        require(company.account == _companyAddress, "Company does not exist");

        return (company.name, company.numJobPostings);
    }

    // function getAppliedCandidates(uint256 _jobPostingId) public view returns (address[] memory) {
    //     JobPosting storage jobPosting = jobPostings[_jobPostingId];
    //     require(jobPosting.id > 0, "Job posting does not exist");

    //     uint256 numApplications = jobPosting.numApplications;
    //     address[] memory candidatesArr = new address[](numApplications);

    //     uint256 index = 0;
    //     for (uint256 i = 1; i <= candidates.length; i++) {
    //         Candidate storage candidate = candidates[i];
    //         if (candidate.appliedJobPostings[_jobPostingId] > 0) {
    //             candidatesArr[index] = candidate.account;
    //             index++;
    //         }
    //     }

    //     return candidatesArr;
    // }

    function withdraw() public {
        Candidate storage candidate = candidates[msg.sender];
        require(candidate.account == msg.sender, "Only candidates can withdraw");
        require(candidate.numApplications > 0, "No job applications to withdraw");

        uint256[] memory jobPostingIds = getAppliedJobPostingIds(msg.sender);
        for (uint256 i = 0; i < jobPostingIds.length; i++) {
            uint256 jobPostingId = jobPostingIds[i];
            delete jobPostings[jobPostingId].appliedCandidates[msg.sender];
            delete candidates[msg.sender].appliedJobPostings[jobPostingId];
            jobPostings[jobPostingId].numApplications--;
            candidates[msg.sender].numApplications--;
        }
    }

    function getAppliedJobPostingIds(address _candidateAddress) public view returns (uint256[] memory jobPostingIds) {
        Candidate storage candidate = candidates[_candidateAddress];
        require(candidate.account == _candidateAddress, "Candidate does not exist");

        uint256[] memory ids = new uint256[](candidate.numApplications);
        uint256 counter = 0;

        for (uint256 i = 1; i <= lastJobPostingId; i++) {
            if (jobPostings[i].id > 0 && jobPostings[i].appliedCandidates[_candidateAddress] > 0) {
                ids[counter] = i;
                counter++;
            }
        }

        return ids;
    }
    function getLastJobPostingIds(uint256 numIds) public view returns (uint256[] memory) {
        require(numIds > 0, "Number of IDs must be greater than zero");

        if (numIds > lastJobPostingId) {
            numIds = lastJobPostingId;
        }

        uint256[] memory jobPostingIds = new uint256[](numIds);
        for (uint256 i = 0; i < numIds; i++) {
            jobPostingIds[i] = lastJobPostingId - i;
        }
        return jobPostingIds;
    }
    function expressInterestInCompany(address _companyAddress) public {
        require(candidates[msg.sender].account == msg.sender, "Only candidates can express interest in companies");

        candidates[msg.sender].interestedCompanies[_companyAddress] = block.timestamp;
    }

    function removeInterestInCompany(address _companyAddress) public {
        require(candidates[msg.sender].account == msg.sender, "Only candidates can remove interest in companies");

        delete candidates[msg.sender].interestedCompanies[_companyAddress];
    }

}