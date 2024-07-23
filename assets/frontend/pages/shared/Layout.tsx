import { usePage } from "@inertiajs/react";
import React from 'react'
import Flash from "./Flash";

export default function Layout({children, mainNavLinks}) {
  const {flash} = usePage().props;

  // const hasFlash = flash && Object.keys(flash).length > 0;
  return <div className="pageContainer">
    <main>
      {children}
    </main>
  </div>;
}