import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://app:3000';

export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '2m', target: 100 },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_failed: ['rate<0.05'], // allow more failures under stress
  },
};

export default function () {
  const res = http.get(BASE_URL);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1);
}