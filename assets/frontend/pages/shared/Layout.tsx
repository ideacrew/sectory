import { usePage } from "@inertiajs/react";
import Footer from "./Footer";
import MainNav from "./MainNav"
import React from 'react'
import Flash from "./Flash";

export default function Layout({children, mainNavLinks}) {
  const {flash} = usePage().props;

  // const hasFlash = flash && Object.keys(flash).length > 0;
  return <div className="pageContainer">
    <MainNav mainNavLinks={mainNavLinks}></MainNav>
    <main>
      {children}
    </main>
    <Footer mainNavLinks={mainNavLinks}></Footer>
  </div>;
}