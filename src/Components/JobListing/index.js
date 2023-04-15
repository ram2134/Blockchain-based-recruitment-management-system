import React from "react";
import JobPosting from "./JobPosting";

function JobsList(props) {
  const jobPostings = props.jobPostings.map((job) => (
    <JobPosting
      key={job.id}
      jobTitle={job.jobTitle}
      companyName={job.companyName}
      jobDescription={job.jobDescription}
      location={job.location}
      onApply={() => props.onApply(job.id)}
    />
  ));

  return <div className="jobs-list">{jobPostings}</div>;
}

export default JobsList;
