// assets/js/app.jsx

import React from "react";
import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";
import * as dic from "./pages/Deliverables/IndexComponent";
import * as dsc from "./pages/Deliverables/ShowComponent";
import * as dvsc from "./pages/DeliverableVersions/ShowComponent";
import * as dvnc from "./pages/DeliverableVersions/NewComponent";
import * as vssc from "./pages/VersionSboms/ShowComponent";
import * as vanc from "./pages/VulnerabilityAnalyses/NewComponent";
import * as vaec from "./pages/VulnerabilityAnalyses/EditComponent";
import * as vaic from "./pages/VulnerabilityAnalyses/IndexComponent";
import * as hic from "./pages/Home/IndexComponent";
import axios from "axios";
import "./pages.css";
import Layout from "./pages/shared/Layout";

const pages = {
  'Deliverables/IndexComponent': dic,
  'Deliverables/ShowComponent': dsc,
  'DeliverableVersions/NewComponent': dvnc,
  'DeliverableVersions/ShowComponent': dvsc,
  'VersionSboms/ShowComponent': vssc,
  'VulnerabilityAnalyses/IndexComponent': vaic,
  'VulnerabilityAnalyses/NewComponent': vanc,
  'VulnerabilityAnalyses/EditComponent': vaec,
  'Home/IndexComponent': hic
}

axios.defaults.xsrfHeaderName = "x-csrf-token";

if (document.getElementById("app")) {
  createInertiaApp({
    resolve: (name) => {
      const thePage = pages[name];
      thePage.default.layout = (page) => {
        const layout = thePage.layout || Layout;
        return <Layout children={page} mainNavLinks={page.props.mainNavLinks}></Layout>
      }
      return thePage;
    },
    setup({ App, el, props }) {
      createRoot(el).render(<App {...props} />);
    },
  });
}