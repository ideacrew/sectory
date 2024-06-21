import { Head, Link } from '@inertiajs/react'
import React from 'react'

export default function IndexComponent({ deliverables }) {
  const deliverableTags = deliverables.map((d) => {
    return <tr key={d.id}>
      <td><a href={d.versions_url}>{d.name}</a></td>
    </tr>
  });

  return (
   <>
     <Head title="Deliverables"/>

     <table>
      <thead>
        <tr>
          <th>Name</th>
        </tr>
      </thead>
      <tbody>
        {deliverableTags}
      </tbody>
     </table>
   </>
  )
}