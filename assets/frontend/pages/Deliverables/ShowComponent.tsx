import { Head, Link } from '@inertiajs/react'
import React from 'react'

export default function ShowComponent({ deliverable }) {
  const deliverableVersionTags = deliverable.deliverable_versions.map((d) => {
    return <tr key={d.id}>
      <td><a href={d.deliverable_version_url}>{d.version}</a></td>
      <td><a href={d.deliverable_version_url}>{d.git_sha}</a></td>
    </tr>
  });

  return (
   <>
     <Head title="Deliverable"/>

     <dl className="item-summary">
      <dt>Deliverable</dt>
      <dd>{deliverable.name}</dd>
     </dl>

     <table className='list-table'>
      <thead>
        <tr>
          <th>Version</th>
          <th>Git SHA</th>
        </tr>
      </thead>
      <tbody>
        {deliverableVersionTags}
      </tbody>
     </table>
   </>
  )
}