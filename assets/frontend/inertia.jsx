// assets/js/app.jsx

import React from "react";
import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";
import * as dic from "./pages/Deliverables/IndexComponent";
import * as dsc from "./pages/Deliverables/ShowComponent";
import * as dvsc from "./pages/DeliverableVersions/ShowComponent";
import * as vssc from "./pages/VersionSboms/ShowComponent";

const pages = {
  'Deliverables/IndexComponent': dic,
  'Deliverables/ShowComponent': dsc,
  'DeliverableVersions/ShowComponent': dvsc,
  'VersionSboms/ShowComponent': vssc
}

createInertiaApp({
  resolve: (name) => {
    return pages[name];
  },
  setup({ App, el, props }) {
    createRoot(el).render(<App {...props} />);
  },
});