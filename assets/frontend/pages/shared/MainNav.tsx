import { Link } from "@inertiajs/react"
import React from 'react'
import NavLinks from "./NavLinks";

export default function MainNav({mainNavLinks}) {
  return <>
    <nav className="main-nav">
      <img src="/images/ideacrew_icon.svg"/>
      <NavLinks mainNavLinks={mainNavLinks}/>
    </nav>
  </>;
}