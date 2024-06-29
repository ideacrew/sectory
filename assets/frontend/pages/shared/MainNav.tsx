import { Link } from "@inertiajs/react"
import React from 'react'

export default function MainNav({mainNavLinks}) {
  return <>
    <nav className="main-nav">
      <img src="/images/ideacrew_icon.svg"/>
      <ol>
        <li><Link href={mainNavLinks.homeUrl}>Home</Link></li>
        <li><Link href={mainNavLinks.deliverablesUrl}>Deliverables</Link></li>
      </ol>
    </nav>
  </>;
}