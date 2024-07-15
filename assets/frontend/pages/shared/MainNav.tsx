import { usePage } from "@inertiajs/react"
import axios from "axios";
import React from 'react'
import NavLinks from "./NavLinks";

export default function MainNav({mainNavLinks}) {
  return <>
    <nav className="main-nav">
      <img src="/images/ideacrew_icon.svg"/>
      <NavLinks mainNavLinks={mainNavLinks}/>
      <ul className="py-1">
        <li className="py-2"><a href={mainNavLinks.settingsUrl}>Settings</a></li>
        <li className="py-2">
          <form action={mainNavLinks.logoutUrl} method="post">
            <input name="_method" type="hidden" value="delete"/>
            <button type="submit">Logout</button>
          </form>
        </li>
      </ul>
    </nav>
  </>;
}