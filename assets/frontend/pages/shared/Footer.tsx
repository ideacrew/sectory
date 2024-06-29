import React from 'react';
import NavLinks from './NavLinks';
import "./Footer.css";

export default function Footer({mainNavLinks}) {
  return <footer className="footer">
    <div className="footer-logo">
      <img src="/images/full-logo.svg"></img>
    </div>
    <nav className='footer-nav'>
      <NavLinks mainNavLinks={mainNavLinks}/>
    </nav>
  </footer>;
}