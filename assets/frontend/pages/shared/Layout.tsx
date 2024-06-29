import Footer from "./Footer";
import MainNav from "./MainNav"
import React from 'react'

export default function Layout({children, mainNavLinks}) {
  return <div className="pageContainer">
    <MainNav mainNavLinks={mainNavLinks}></MainNav>
    <main>
      {children}
    </main>
    <Footer mainNavLinks={mainNavLinks}></Footer>
  </div>;
}