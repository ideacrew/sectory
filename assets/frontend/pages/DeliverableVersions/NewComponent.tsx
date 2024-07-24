import { Head, usePage, router } from '@inertiajs/react'
import { useState } from 'react'
import React from 'react'


export default function NewComponent({ create_url, deliverable_id, deliverable_name, version, git_sha }) {
  const { errors } = usePage().props

  const [values, setValues] = useState({
    deliverable_id: deliverable_id,
    version: version || "",
    git_sha: git_sha || ""
  });

  function handleChange(e) {
    setValues(values => ({
      ...values,
      [e.target.id]: e.target.value,
    }))
  }

  function handleSubmit(e) {
    e.preventDefault()
    router.post(create_url, values)
  }

  return (
    <>
      <Head title="New Deliverable Version" />
      <h2>New Version for {deliverable_name}</h2>
      <form onSubmit={handleSubmit} className="deliverable-version-form-new">
        <div className='form-horizontal'>
          <label htmlFor="version">
            Version
          </label>
          <input type="text" id="version" name="version" onChange={handleChange} value={values.version}/>
          {errors.version && <div className="errors">{errors.version}</div>}
          <label htmlFor="git_sha">
            Git SHA
          </label>
          <input type="text" id="git_sha" name="git_sha" onChange={handleChange} value={values.git_sha}/>
          {errors.git_sha && <div className="errors">{errors.git_sha}</div>}
          <input type='submit' value="Submit" className="btn btn-primary" />
        </div>
      </form>
    </>
  )
}