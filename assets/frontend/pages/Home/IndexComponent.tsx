import { Head } from '@inertiajs/react'
import React from 'react'

export default function IndexComponent({ deliverables_url, stats }) {
  return (
    <>
      <Head title="Sectory" />

      <h2>Sectory is currently tracking:</h2>
      <table className="home-statistics">
        <thead>
          <tr>
            <th>Category</th>
            <th>Count</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Deliverables</td>
            <td>{stats.deliverables}</td>
          </tr>
          <tr>
            <td>Versions</td>
            <td>{stats.versions}</td>
          </tr>
          <tr>
            <td>SBOMs</td>
            <td>{stats.sboms}</td>
          </tr>
          <tr>
            <td>Artifacts</td>
            <td>{stats.artifacts}</td>
          </tr>
          <tr>
            <td>Analyses</td>
            <td>{stats.analyses}</td>
          </tr>
        </tbody>
      </table>
    </>
  )
}