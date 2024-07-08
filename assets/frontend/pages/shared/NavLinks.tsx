import { Link } from "@inertiajs/react"
import React from "react";

export default function NavLinks({mainNavLinks}) {
  return <ol className="py-1">
        <li className="py-2"><Link href={mainNavLinks.homeUrl}>Home</Link></li>
        <li className="py-2"><Link href={mainNavLinks.deliverablesUrl}>Deliverables</Link></li>
        <li className="py-2"><Link href={mainNavLinks.vulnerabilityAnalysesUrl}>Vulnerability Analyses</Link></li>
      </ol>
}