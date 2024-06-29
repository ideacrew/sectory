import { Link } from "@inertiajs/react"
import React from "react";

export default function NavLinks({mainNavLinks}) {
  return <ol>
        <li><Link href={mainNavLinks.homeUrl}>Home</Link></li>
        <li><Link href={mainNavLinks.deliverablesUrl}>Deliverables</Link></li>
      </ol>
}