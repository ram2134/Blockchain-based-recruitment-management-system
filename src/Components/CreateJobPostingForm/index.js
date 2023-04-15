// import React, { useState } from "react";
// import JobPosting from "../JobPosting";

// const CreateJobPostingForm = ({ onSubmit }) => {
//   const [jobTitle, setJobTitle] = useState("");
//   const [companyName, setCompanyName] = useState("");
//   const [jobDescription, setJobDescription] = useState("");

//   const handleSubmit = (event) => {
//     event.preventDefault();
//     const newJobPosting = {
//       jobTitle: jobTitle,
//       companyName: companyName,
//       jobDescription: jobDescription,
//     };
//     onSubmit(newJobPosting);
//     setJobTitle("");
//     setCompanyName("");
//     setJobDescription("");
//   };

//   return (
//     <form onSubmit={handleSubmit}>
//       <div>
//         <label htmlFor="jobTitle">Job Title:</label>
//         <input
//           type="text"
//           id="jobTitle"
//           value={jobTitle}
//           onChange={(event) => setJobTitle(event.target.value)}
//           required
//         />
//       </div>
//       <div>
//         <label htmlFor="companyName">Company Name:</label>
//         <input
//           type="text"
//           id="companyName"
//           value={companyName}
//           onChange={(event) => setCompanyName(event.target.value)}
//           required
//         />
//       </div>
//       <div>
//         <label htmlFor="jobDescription">Job Description:</label>
//         <textarea
//           id="jobDescription"
//           value={jobDescription}
//           onChange={(event) => setJobDescription(event.target.value)}
//           required
//         ></textarea>
//       </div>
//       <button type="submit">Post Job</button>
//     </form>
//   );
// };

import React, { useState } from "react";
import JobPosting from "../JobPosting";

const CreateJobPostingForm = ({ onSubmit }) => {
  const [jobTitle, setJobTitle] = useState("");
  const [companyName, setCompanyName] = useState("");
  const [jobDescription, setJobDescription] = useState("");

  const handleSubmit = (event) => {
    event.preventDefault();
    const newJobPosting = {
      jobTitle: jobTitle,
      companyName: companyName,
      jobDescription: jobDescription,
    };
    onSubmit(newJobPosting);
    setJobTitle("");
    setCompanyName("");
    setJobDescription("");
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="jobTitle">Job Title:</label>
        <input
          type="text"
          id="jobTitle"
          value={jobTitle}
          onChange={(event) => setJobTitle(event.target.value)}
          required
        />
      </div>
      <div>
        <label htmlFor="companyName">Company Name:</label>
        <input
          type="text"
          id="companyName"
          value={companyName}
          onChange={(event) => setCompanyName(event.target.value)}
          required
        />
      </div>
      <div>
        <label htmlFor="jobDescription">Job Description:</label>
        <textarea
          id="jobDescription"
          value={jobDescription}
          onChange={(event) => setJobDescription(event.target.value)}
          required
        ></textarea>
      </div>
      <button type="submit">Post Job</button>
    </form>
  );
};

const ParentComponent = () => {
  const onSubmit = (newJobPosting) => {
    // Do something with the new job posting
    window.alert("New job posting submitted:", newJobPosting);
  };

  return <CreateJobPostingForm onSubmit={onSubmit} />;
};

export default ParentComponent;

// export default ParentComponent;
