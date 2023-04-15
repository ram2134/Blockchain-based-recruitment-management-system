
// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract Final {
    
    struct Candidate {
        uint id;
        bytes32 nameHash;
        bytes32 skillsHash;
        bool isActive;
    }
    
    struct Company {
        uint id;
        bytes32 nameHash;
        bytes32 industryHash;
        bool isActive;
    }
    
    struct JobPosting {
        uint id;
        uint companyId;
        string title;
        string description;
        string requirements;
        uint salary;
        bool isActive;
    }
    
    struct JobApplication {
        uint candidateId;
        uint jobId;
        bool isActive;
    }
    
    mapping (uint => Candidate) public candidates;
    uint public candidatesCount;
    
    mapping (uint => Company) public companies;
    uint public companiesCount;
    
    mapping (uint => JobPosting) public jobPostings;
    uint public jobPostingsCount;
    
    mapping (uint => mapping(uint => JobApplication)) public jobApplications;
    
    event CandidateCreated(uint indexed candidateId, bytes32 nameHash, bytes32 skillsHash);

    function createCandidateProfile(bytes32 _nameHash, bytes32 _skillsHash) public {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _nameHash, _skillsHash, true);
        emit CandidateCreated(candidatesCount, _nameHash, _skillsHash);
    }

    event CompanyCreated(uint indexed companyId, bytes32 nameHash, bytes32 industryHash);

    function createCompanyProfile(bytes32 _nameHash, bytes32 _industryHash) public {
        companiesCount++;
        companies[companiesCount] = Company(companiesCount, _nameHash, _industryHash, true);
        emit CompanyCreated(companiesCount, _nameHash, _industryHash);
    }

    event JobPostingCreated(uint indexed jobId, uint indexed companyId, string title, string description, string requirements, uint salary);

    function createJobPosting(uint _companyId, string memory _title, string memory _description, string memory _requirements, uint _salary) public {
        require(companies[_companyId].isActive, "Company not active");
        jobPostingsCount++;
        jobPostings[jobPostingsCount] = JobPosting(jobPostingsCount, _companyId, _title, _description, _requirements, _salary, true);
        emit JobPostingCreated(jobPostingsCount, _companyId, _title, _description, _requirements, _salary);
    }

    event JobApplicationCreated(uint indexed candidateId, uint indexed jobId);

    function applyToJobPosting(uint _candidateId, uint _jobId) public {
        require(candidates[_candidateId].isActive, "Candidate not active");
        require(jobPostings[_jobId].isActive, "Job posting not active");
        jobApplications[_jobId][_candidateId] = JobApplication(_candidateId, _jobId, true);
        emit JobApplicationCreated(_candidateId, _jobId);
    }
    function getCandidateId(bytes32 _nameHash, bytes32 _skillsHash) public view returns (uint) {
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].nameHash == _nameHash && candidates[i].skillsHash == _skillsHash) {
                return i;
            }
        }
        return 0;
    }
    
    function getCompanyId(bytes32 _nameHash, bytes32 _industryHash) public view returns (uint) {
        for (uint i = 1; i <= companiesCount; i++) {
            if (companies[i].nameHash == _nameHash && companies[i].industryHash == _industryHash) {
                return i;
            }
        }
        return 0;
    }
}