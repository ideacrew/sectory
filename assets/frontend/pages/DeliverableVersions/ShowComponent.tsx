import { Head, Link } from '@inertiajs/react'
import React from 'react'

export default function ShowComponent({ deliverable_version }) {
  const deliverableSbomTags = deliverable_version.version_sboms.map((d) => {
    return <tr key={d.id}>
      <td><a href={d.version_sbom_url}>{d.name}</a></td>
      <td><a href={d.analyzed_version_sbom_url}>Analyzed Version</a></td>
    </tr>
  });

  return (
   <>
     <Head title="Deliverable"/>

     <dl>
      <dt>Deliverable</dt>
      <dd>{deliverable_version.deliverable.name}</dd>
      <dt>Version</dt>
      <dd>{deliverable_version.version}</dd>
      <dt>Git SHA</dt>
      <dd>{deliverable_version.git_sha}</dd>
     </dl>

     <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Other Actions</th>
        </tr>
      </thead>
      <tbody>
        {deliverableSbomTags}
      </tbody>
     </table>
   </>
  )
}