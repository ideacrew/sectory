import { Head, Link } from '@inertiajs/react'
import React from 'react'

export default function IndexComponent({ deliverables }) {
  const deliverableTags = deliverables.map((d) => {
    return <tr key={d.id}>
      <td><Link href={d.versions_url}>{d.name}</Link></td>
    </tr>
  });

  return (
   <>
     <Head title="Deliverables"/>

     <table className='list-table'>
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