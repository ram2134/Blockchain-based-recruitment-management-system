import React from "react";

const JobPosting = (newJobPosting) => {
  return (
    <div>
      <h2>{newJobPosting.jobTitle}</h2>
      <h3>{newJobPosting.companyName}</h3>
      <p>{newJobPosting.jobDescription}</p>
    </div>
  );
};

export default JobPosting;
