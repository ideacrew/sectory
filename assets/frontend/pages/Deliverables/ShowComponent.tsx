import { Head, Link } from '@inertiajs/react'
import React from 'react'

export default function ShowComponent({ deliverable, new_deliverable_version_url }) {
  const deliverableVersionTags = deliverable.deliverable_versions.map((d) => {
    return <tr key={d.id}>
      <td><Link href={d.deliverable_version_url}>{d.version}</Link></td>
      <td className='mono'><Link href={d.deliverable_version_url}>{d.git_sha}</Link></td>
    </tr>
  });

  return (
   <>
     <Head title="Deliverable"/>

     <dl className="item-summary">
      <dt>Deliverable</dt>
      <dd>{deliverable.name}</dd>
     </dl>

     <h2 className='text-4xl font-extrabold'>Versions</h2>

     <Link href={new_deliverable_version_url}>New Version</Link>

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